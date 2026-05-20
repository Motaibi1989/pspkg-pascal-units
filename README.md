# pspkg Pascal Units

Cross-platform Free Pascal units for system information, logging, command execution, and network checks.

## Files

```text
pspkg/
├─ pspkg.pas
├─ uCore.pas
├─ uLOGM.pas
├─ uSYSM.pas
├─ uNETM.pas
└─ .github/workflows/build.yml
```

## Build

```bash
fpc pspkg.pas
```

## Linux dependencies

```bash
sudo apt update
sudo apt install -y fpc util-linux pciutils usbutils dmidecode iproute2 procps systemd
```

## Run

```bash
./pspkg
```

## GitHub push

```bash
git init
git add .
git commit -m "Initial Pascal units"
git branch -M main
git remote add origin https://github.com/Motaibi1989/pspkg-pascal-units.git
git push -u origin main
```
