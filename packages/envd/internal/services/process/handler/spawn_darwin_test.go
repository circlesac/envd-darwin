//go:build darwin

package handler

import (
	"os/user"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/e2b-dev/infra/packages/envd/internal/services/cgroups"
	rpc "github.com/e2b-dev/infra/packages/envd/internal/services/spec/process"
)

func TestDarwinCommandUsesLoginCredentials(t *testing.T) {
	t.Parallel()

	u, err := user.Current()
	require.NoError(t, err)
	logger := zerolog.Nop()
	cmd, _, err := newCommand(t.Context(), u, &rpc.StartRequest{
		Process: &rpc.ProcessConfig{Cmd: "/bin/sh", Args: []string{"-c", "printf darwin-envd"}},
	}, &logger, cgroups.NewNoopManager())
	require.NoError(t, err)
	out, err := cmd.CombinedOutput()
	require.NoError(t, err, string(out))
	require.Equal(t, "darwin-envd", string(out))
}
