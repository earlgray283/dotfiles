{ ... }:

{
  xdg.configFile."karabiner/karabiner.json" = {
    text = builtins.toJSON {
      profiles = [
        {
          devices = [
            {
              identifiers.is_keyboard = true;
              simple_modifications = [
                {
                  from.key_code = "caps_lock";
                  to = [ { key_code = "left_command"; } ];
                }
                {
                  from.key_code = "left_command";
                  to = [ { key_code = "japanese_eisuu"; } ];
                }
                {
                  from.key_code = "right_command";
                  to = [ { key_code = "japanese_kana"; } ];
                }
              ];
            }
            {
              identifiers = {
                is_keyboard = true;
                product_id = 33;
                vendor_id = 1278;
              };
              simple_modifications = [
                {
                  from.key_code = "left_control";
                  to = [ { key_code = "left_command"; } ];
                }
                {
                  from.key_code = "left_option";
                  to = [ { key_code = "left_control"; } ];
                }
                {
                  from.key_code = "left_command";
                  to = [ { key_code = "japanese_eisuu"; } ];
                }
                {
                  from.key_code = "right_command";
                  to = [ { key_code = "japanese_kana"; } ];
                }
              ];
            }
          ];
          name = "Default profile";
          selected = true;
          virtual_hid_keyboard.keyboard_type_v2 = "ansi";
        }
      ];
    };
    onChange = ''
      /bin/launchctl kickstart -k gui/$UID/org.pqrs.service.agent.Karabiner-Console-User-Server
    '';
  };
}
