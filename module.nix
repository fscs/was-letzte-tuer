{ outputs }:
{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.services.was-letzte-tuer =
    let
      t = lib.types;
    in
    {
      enable = lib.mkEnableOption "enable the was-letzte-tuer server";

      package = lib.mkOption {
        description = "server package";
        type = t.package;
        default = outputs.packages.${pkgs.stdenv.system}.default;
      };

      port = lib.mkOption {
        description = "port to run on";
        type = t.port;
        default = 8080;
      };

      dataDir = lib.mkOption {
        description = "directory to store the database in";
        type = t.nonEmptyStr;
        default = "was-letzte-tuer";
        apply = v: "/var/lib/${v}";
      };

      gcInterval = lib.mkOption {
        description = "time interval to between gc's. see systemd.time(7)";
        type = lib.types.nonEmptyStr;
        default = "weekly";
      };
    };

  config =
    let
      cfg = config.services.was-letzte-tuer;
    in
    lib.mkIf cfg.enable {
      users.groups.was-letzte-tuer = { };
      users.users.was-letzte-tuer = {
        isSystemUser = true;
        group = "was-letzte-tuer";
      };

      systemd.timers.was-letzte-tuer-gc = {
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = cfg.gcInterval;
      };

      systemd.services.was-letzte-tuer-gc = {
        script = "${lib.getExe pkgs.curl} -XPOST http://localhost:${toString cfg.port}/gc --no-progress-meter";

        serviceConfig.Type = "oneshot";
      };

      systemd.services.was-letzte-tuer = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe cfg.package} ${toString cfg.port} ${cfg.dataDir}";
          Type = "exec";
          User = config.users.users.was-letzte-tuer.name;
          Restart = "always";
          RestartSec = 5;
          StateDirectory = builtins.baseNameOf cfg.dataDir;
          LimitNOFILE = "8192";
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          DeviceAllow = [ "" ];
          DevicePolicy = "closed";
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "noaccess";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          UMask = "0077";
        };
      };
    };
}
