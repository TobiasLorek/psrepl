(defun psrepl/set-pid (pid)
  "Set PID as the psrepl process ID."
  (setq psrepl/pid))

(defun psrepl/send-to-powershell (args)
  "Invoke a PowerShell script asynchronously, passing ARGS as arguments.
   Arguments are encoded using base64."
  (let* ((script ".\\WriteToPsRepl.ps1")
         (pid (format "%d" psrepl/pid))
         (encoded-args (mapcar (lambda (arg) (base64-encode-string arg 't)) args))
         (cmd (concat "powershell.exe -ExecutionPolicy Bypass -File "
                      script " " pid " " (mapconcat 'identity encoded-args " "))))
    (async-start-process "powershell" "powershell" nil cmd)))

(defun my/eval-region-to-powershell (orig-fun &rest args)
  "Advice function to modify behavior of `eval/send-region-to-repl'.

   This function intercepts the call to `eval/send-region-to-repl' and
   modifies its behavior to send the lines as a list of strings to the
   function `psrepl/send-to-powershell' only when the major mode is
   `powershell-mode'. Otherwise, it delegates to the original function."
  (if (eq major-mode 'powershell-mode)
      (let ((region-str (buffer-substring-no-properties
                         (region-beginning) (region-end))))
        (psrepl/send-to-powershell (split-string region-str "\n")))
    (apply orig-fun args)))

(defun psrepl/set-breakpoint (linenum filename)
  "Sets a breakpoint at LINENUM in FILENAME using `Set-PSBreakpoint` cmdlet."
  (psrepl/send-to-powershell
   (list (format "Set-PSBreakpoint -Line %d -Script \"%s\"" linenum filename))))

(defun psrepl/set-breakpoint-here ()
  "Sets a breakpoint at the current cursor position in the current buffer using `Set-PSBreakpoint` cmdlet."
  (interactive)
  (let ((linenum (line-number-at-pos))
        (filename (buffer-file-name)))
    (when filename
      (psrepl/set-breakpoint linenum filename))))

(defun psrepl/open-current-file ()
  "Opens the current file in the PowerShell REPL using `.` operator."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (psrepl/send-to-powershell (list (concat ". \"" filename "\""))))))

(global-set-key (kbd "C-c C-o") #'psrepl/open-current-file)
(global-set-key (kbd "C-c C-b") #'psrepl/set-breakpoint-here)
