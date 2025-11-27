package main

import (
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"runtime"
	"strings"
)

const (
	// linux
	xclip  = "xclip"
	wlcopy = "wl-copy"
	xsell  = "xsel"
	// windows
	clip = "clip"
	// mac
	pbcopy = "pbcopy"
)

const (
	colorReset = "\033[0m"
	colorGreen = "\033[32m"
	colorWhite = "\033[97m"
	colorCyan  = "\033[36m"
)

func main() {
	if err := run(); err != nil {
		_ = displayPopup("Error: " + err.Error())
		os.Exit(1)
	}
}

func run() error {
	if err := ensureTmux(); err != nil {
		return err
	}

	text, err := getTmuxBuffer()
	if err != nil {
		return err
	}

	clipboardTool, exists := hasClipboardTool()
	if !exists {
		return errors.New("no clipboard tool found")
	}

	if err := sendToClipboard(clipboardTool, text); err != nil {
		return err
	}

	showSuccess(text)

	return nil
}

func ensureTmux() error {
	_, err := exec.LookPath("tmux")
	if err != nil {
		return errors.New("tmux not found")
	}
	return nil
}

func getTmuxBuffer() (string, error) {
	cmd := exec.Command("tmux", "show-buffer")
	out, err := cmd.Output()
	if err != nil {
		return "", errors.New("there is nothing in the buffer")
	}
	text := string(out)
	if text == "" {
		return "", errors.New("no text selected")
	}

	return text, nil
}

func hasClipboardTool() (string, bool) {
	tools := getPlatformTools()

	for _, tool := range tools {
		if hasBinary(tool) {
			return tool, true
		}
	}
	return "", false
}

func getPlatformTools() []string {
	switch runtime.GOOS {
	case "linux":
		return []string{xclip, wlcopy, xsell}
	case "windows":
		return []string{clip}
	case "darwin":
		return []string{pbcopy}
	default:
		return nil
	}
}

func sendToClipboard(tool, text string) error {
	args := getToolArgs(tool)
	return pipTo(tool, text, args...)
}

func getToolArgs(tool string) []string {
	var zero []string
	switch tool {
	case xclip:
		return []string{"-selection", "clipboard"}
	case wlcopy:
		return zero
	case xsell:
		return []string{"--clipboard", "--input"}
	default:
		return zero
	}
}

func pipTo(tool, text string, args ...string) error {
	cmd := exec.Command(tool, args...)

	input, err := cmd.StdinPipe()
	if err != nil {
		return err
	}
	if err := cmd.Start(); err != nil {
		return err
	}

	_, _ = io.WriteString(input, text)
	_ = input.Close()
	return cmd.Wait()
}

func hasBinary(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}

func displayPopup(text string) error {
	colored := fmt.Sprintf(
		"%s ✔ Copied text!%s\n\n"+
			"%s%s%s\n\n"+
			"%s Press ENTER to close...%s",
		colorGreen, colorReset,
		colorWhite, text, colorReset,
		colorCyan, colorReset,
	)

	return exec.Command(
		"tmux", "display-popup", "-E",
		fmt.Sprintf("printf \"%s\"; read _", escapeForShell(colored)),
	).Run()
}

func escapeForShell(s string) string {
	// impede que aspas causem quebra na string
	return strings.ReplaceAll(s, "\"", "\\\"")
}

func showSuccess(text string) {
	preview := text
	if len(text) > 350 {
		preview = text[:350] + "..."
	}

	msg := fmt.Sprintf(
		"#[fg=green]✔ Texto copiado!\n\n#[fg=white]%s",
		preview,
	)

	_ = displayPopup(msg)
}
