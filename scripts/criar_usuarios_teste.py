"""Compatibilidade com o comando anterior; usa o seed oficial sem redefinir senhas."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scripts.inicializar_banco import main

if __name__ == "__main__":
    main()
