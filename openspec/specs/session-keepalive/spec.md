# session-keepalive Specification

## Purpose
Prevent Linux VM session loss on Android / Crostini environments by keeping user systemd instances alive, persisting terminal multiplexer sessions, and maintaining SSH connection keep-alives.

## Requirements

### Requirement: Systemd User Session Linger Activation
The system SHALL provide an activation script `enableLinger` in `services.session-keepalive` to automatically enable systemd logind lingering for the user profile.

#### Scenario: Enabling linger on Home Manager activation
- **WHEN** `services.session-keepalive.enableLinger` is `true`
- **THEN** Home Manager activation runs `loginctl enable-linger <username>` so systemd user services persist after logout or disconnect.

### Requirement: Systemd User Keep-Alive Daemon
The `services.session-keepalive` module SHALL provide a systemd user service `session-keepalive.service` running `sleep infinity`.

#### Scenario: User session background persistence
- **WHEN** `services.session-keepalive.enable` is `true`
- **THEN** `session-keepalive.service` starts under `default.target` and stays active to prevent systemd user session termination.

### Requirement: Tmux Session Resurrection & Server Daemon
The system SHALL provide Tmux configuration with `tmux-resurrect` and `tmux-continuum` plugins and a `tmux-server.service` systemd unit.

#### Scenario: Preserving terminal sessions across VM restarts
- **WHEN** a terminal session is disconnected or the VM is restarted
- **THEN** Tmux auto-saves workspace state every 15 minutes and restores running panes/windows upon session re-attach.

### Requirement: SSH Client Keep-Alive
The system SHALL configure SSH keep-alive settings in `programs.ssh` when `services.session-keepalive.enableSshKeepAlive` is `true`.

#### Scenario: Mobile network switching or idle timeout
- **WHEN** an SSH connection experiences idle network conditions or network switching on Android
- **THEN** `ServerAliveInterval 30` and `ServerAliveCountMax 10` send periodic keep-alive probes to prevent socket drops.
