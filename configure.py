import os
import argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("profile", help="Profile to configure")


def files(profile: str) -> list[tuple[Path, Path]]:
    return [
        (
            Path(__file__).parent / ".zshrc",
            Path(Path.home(), ".zshrc"),
        ),
        (
            Path(__file__).parent / ".zsh_history",
            Path(Path.home(), ".zsh_history"),
        ),
        (
            Path(__file__).parent / profile / ".aws",
            Path(Path.home(), ".aws"),
        ),
        (
            Path(__file__).parent / profile / ".gitconfig",
            Path(Path.home(), ".gitconfig"),
        ),
    ]


def main():
    args = parser.parse_args()

    for src, dest in files(args.profile):
        try:
            os.symlink(src, dest)
        except FileExistsError:
            print(f"symlink: file {dest} already exists")


if __name__ == "__main__":
    main()
