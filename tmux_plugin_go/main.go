package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

func main() {
	execTmuxCmd("show-buffer")
}

func execTmuxCmd(args ...string) {
	err := checkIsTmuxInstalled()
	if err != nil {
		_ = displayMessage(err.Error())
		os.Exit(1)
	}

	cmd := exec.Command("tmux", args...)
	out, err := cmd.Output()
	if err != nil {
		_ = displayMessage(err.Error())
		os.Exit(1)
	}

	selectedText := strings.TrimSpace(string(out))
	if len(selectedText) <= 0 {
		_ = displayMessage("Nenhum texto foi selecionado pelo usuário")
		os.Exit(1)
	}

	if err := copyToClipboard(selectedText); err != nil {
		fmt.Println("aconteceu um erro", err.Error())
		os.Exit(1)
	}
}

func copyToClipboard(text string) error {
	cmd := exec.Command("xclip", "-selection", "clipboard")

	stdin, err := cmd.StdinPipe()
	if err != nil {
		return err
	}

	if err := cmd.Start(); err != nil {
		return err
	}

	io.WriteString(stdin, text)
	stdin.Close()

	return cmd.Wait()
}

func checkIsTmuxInstalled() error {
	_, err := exec.LookPath("tmux")
	return err
}

func displayPopup(text string) error {
	return exec.Command("tmux", "display-popup", "-E",
		"printf \"%s\n\nPressione ENTER para fechar...\" \""+text+"\"; read _").Run()
}

func displayMessage(msg string) error {
	return exec.Command("tmux", "display-message", msg).Run()
}
