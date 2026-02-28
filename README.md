# Windows Provisioning Toolkit

A lightweight automation toolkit for provisioning Windows systems.

This tool can:

- Install Windows Updates
- Install applications via Winget
- Export installed software inventory
- Schedule automatic updates at system startup

---

## ⚙️ Configuration: setup.json

The file `setup.json` defines which applications should be installed automatically.

It must be located in the same directory as the scripts.

### Example:

```json
{
  "applications": [
    "Google.Chrome",
    "Adobe.Acrobat.Reader.64-bit",
    "AdGuard.AdGuard",
    "AdGuard.AdGuardVPN",
    "OpenJS.NodeJS.LTS",
    "Oracle.JDK.25",
    "EclipseAdoptium.Temurin.25.JDK",
    "JetBrains.IntelliJIDEA.Community",
    "Google.AndroidStudio",
    "Microsoft.VisualStudioCode",
    "Git.Git",
    "KeePassXCTeam.KeePassXC",
    "Notepad++.Notepad++",
    "RARLab.WinRAR",
    "WinSCP.WinSCP",
    "VideoLAN.VLC"
  ]
}
```

---

## 🧰 Requirements

- Windows 10 or Windows 11
- Administrator privileges
- Winget installed
- Internet connection

---

## 🚀 Usage

Run the BAT launcher as Administrator and select an option from the menu.

---

## 📂 Project Files

| File | Description |
|------|-------------|
| `WindowsProvisioning.bat` | Menu launcher |
| `WindowsProvisioning.ps1` | Main provisioning script |
| `setup.json` | Application list configuration |
| `Provisioning_Log.txt` | Execution log |
| `Installed_Programs.txt` | Exported software inventory |

---

## 🔒 Security Note

The `setup.json` file is intentionally excluded from version control to allow:

- environment-specific configurations
- private/internal software lists
- flexible deployment setups

---

## 📜 License

This project is licensed under the MIT License.

## 🤝 Contributing

Found a bug or have a suggestion for improvement? Please create an issue or pull request.

I appreciate everyone who supports me and the project! For any requests and suggestions, feel free to provide feedback.

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/default-orange.png)](https://www.buymeacoffee.com/madoe21)