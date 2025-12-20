#!/bin/bash

# Fungsi untuk mengecek apakah aplikasi/folder sudah ada
check_installed() {
    if [ -d "$1" ] || command -v "$2" >/dev/null 2>&1; then
        return 0 # Sudah ada
    else
        return 1 # Belum ada
    fi
}
#!/bin/bash

# =================================================================
# Zsh + Oh My Zsh + Plugins Installer for Arch Linux
# =================================================================

ZSH_CUSTOM_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

echo "--- Memulai Proses Instalasi ---"

# 1. Update sistem dan install Zsh, Curl, & Git jika belum ada
echo "[1/6] Mengecek paket dasar (zsh, curl, git)..."
PACKAGES=()
! command -v zsh >/dev/null 2>&1 && PACKAGES+=(zsh)
! command -v curl >/dev/null 2>&1 && PACKAGES+=(curl)
! command -v git >/dev/null 2>&1 && PACKAGES+=(git)

if [ ${#PACKAGES[@]} -gt 0 ]; then
    echo "    Menginstal: ${PACKAGES[@]}"
    sudo pacman -Syu --noconfirm "${PACKAGES[@]}"
else
    echo "    Semua paket dasar sudah terinstal."
fi

# 2. Install Oh My Zsh jika belum ada
echo "[2/6] Mengecek Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "    Menginstal Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "    Oh My Zsh sudah terinstal."
fi

# 3. Install Plugin: zsh-autosuggestions
echo "[3/6] Mengecek plugin zsh-autosuggestions..."
if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    echo "    Mengkloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
else
    echo "    Plugin zsh-autosuggestions sudah ada."
fi

# 4. Install Plugin: zsh-syntax-highlighting
echo "[4/6] Mengecek plugin zsh-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    echo "    Mengkloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
else
    echo "    Plugin zsh-syntax-highlighting sudah ada."
fi

# 5. Konfigurasi .zshrc (Mengaktifkan plugin)
echo "[5/6] Mengonfigurasi .zshrc..."
if [ -f "$HOME/.zshrc" ]; then
    # Cari baris plugins=(git) dan ganti dengan daftar lengkap jika belum diubah
    if grep -q "plugins=(git)" "$HOME/.zshrc" && ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
        echo "    Plugin berhasil diaktifkan di .zshrc."
    else
        echo "    Plugin di .zshrc sudah dikonfigurasi sebelumnya."
    fi
fi

# 6. Set Zsh sebagai Default Shell (via .bashrc dan chsh)
echo "[6/6] Mengatur Zsh sebagai default..."
# Cara 1: chsh (Cara sistem)
if [ "$(basename "$SHELL")" != "zsh" ]; then
    sudo chsh -s $(which zsh) $USER
fi

# Cara 2: .bashrc fallback (Agar langsung aktif tanpa logout)
if ! grep -q "exec zsh" "$HOME/.bashrc"; then
    echo -e "\n# Jalankan Zsh secara otomatis\nif [ -t 1 ]; then\n  exec zsh\nfi" >> "$HOME/.bashrc"
    echo "    Auto-exec Zsh ditambahkan ke .bashrc."
fi

echo "---"
echo "INSTALASI SELESAI!"
echo "Silakan tutup terminal ini dan buka kembali, atau ketik: exec zsh"
echo "---"
