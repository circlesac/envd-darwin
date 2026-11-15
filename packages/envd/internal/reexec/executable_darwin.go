//go:build darwin

package reexec

import "os"

func currentExecutable() string {
	// Darwin has no /proc/self/exe. os.Executable resolves the path of the
	// running Mach-O binary.
	path, err := os.Executable()
	if err != nil {
		return os.Args[0]
	}

	return path
}
