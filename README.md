# Solacula

Tema **Solarized Dark + Dracula** para **VS Code** e **Windows Terminal** (com acrylic glass).

| Componente | Pasta | Distribuição |
|---|---|---|
| VS Code — *Solacula Dark* | [`vscode/`](vscode/) | VS Code Marketplace, Open VSX e `.vsix` nas [Releases](https://github.com/rezendesfelipe/solacula-theme/releases) |
| Windows Terminal — *Solacula Glass* | [`windows-terminal/`](windows-terminal/) | Script `install.ps1` (Fragment + perfil) ou JSON manual |

## Instalação

### VS Code

- **Marketplace:** procure por `Solacula Dark` em Extensões (`Ctrl+Shift+X`), ou rode `code --install-extension rezendesfelipe.solacula-dark`.
- **Open VSX** (VSCodium, Cursor, Windsurf): mesmo ID, `rezendesfelipe.solacula-dark`.
- **Offline:** baixe o `.vsix` da última [release](https://github.com/rezendesfelipe/solacula-theme/releases/latest) e rode `code --install-extension solacula-dark-<versão>.vsix`.

Depois: `Ctrl+K Ctrl+T` → **Solacula Dark**.

### Windows Terminal

Requer PowerShell 7+.

```powershell
git clone https://github.com/rezendesfelipe/solacula-theme
cd solacula-theme/windows-terminal

./install.ps1                                    # só o color scheme (via Fragment, não toca no settings.json)
./install.ps1 -ProfileName "Ubuntu"              # + acrylic e scheme no perfil
./install.ps1 -ProfileName "Ubuntu" -WindowTheme # + abas/janela em vidro (afeta todos os perfis)
```

O script faz backup do `settings.json` (`settings.json.bak-<timestamp>`) antes de alterar. Para desfazer: `./uninstall.ps1` e restaure o backup.

**Manual:** copie os blocos de [`solacula-glass.json`](windows-terminal/solacula-glass.json): `schemes` e `themes` para os arrays de mesmo nome; `profileSettings` para dentro do perfil; `globalSettings` para a raiz.

## Paleta

| ANSI | Normal | Bright | Origem |
|---|---|---|---|
| Black | `#073642` | `#6272A4` | Solarized / Dracula |
| Red | `#FF5555` | `#FF6E6E` | Dracula |
| Green | `#6CCF60` | `#69FF94` | mistura / Dracula |
| Yellow | `#E6C35C` | `#F1FA8C` | mistura / Dracula |
| Blue | `#268BD2` | `#6CB6FF` | Solarized |
| Purple | `#BD93F9` | `#D6ACFF` | Dracula |
| Cyan | `#2AA198` | `#8BE9FD` | Solarized / Dracula |
| White | `#EEE8D5` | `#FDF6E3` | Solarized |

Fundo `#142A36` (Solarized base03 + Dracula bg), texto `#D4DCD6`, cursor `#FF79C6`, seleção `#44475A`.

> O VS Code não tem transparência nativa: o tema do editor é opaco. O efeito de vidro existe apenas no Windows Terminal.

## Desenvolvimento

A paleta vive em [`vscode/gen_theme.py`](vscode/gen_theme.py) (dicionário `P`). Após alterar:

```bash
cd vscode
python3 gen_theme.py          # regenera themes/solacula-dark-color-theme.json
python3 gen_icon.py           # gera icon.png
python3 build_vsix.py         # .vsix local, sem npm
```

## Release e publicação

O workflow [`release.yml`](.github/workflows/release.yml) roda a cada push na `main` que altere `vscode/` ou `windows-terminal/`:

1. Regenera o tema e falha se o JSON commitado estiver dessincronizado do `gen_theme.py`.
2. Empacota o `.vsix` com `@vscode/vsce` e o `.zip` do Windows Terminal.
3. Se a tag `v<versão do package.json>` ainda não existe, cria a GitHub Release com os dois artefatos.
4. Publica no VS Code Marketplace e no Open VSX **se** os secrets existirem:

| Secret | Onde obter |
|---|---|
| `VSCE_PAT` | Azure DevOps → Personal Access Token com escopo **Marketplace → Manage**, organização **All accessible organizations** |
| `OVSX_PAT` | [open-vsx.org](https://open-vsx.org) → Settings → Access Tokens (namespace `rezendesfelipe` precisa existir) |

Para lançar uma versão nova: suba o `version` em `vscode/package.json`, adicione a entrada no `vscode/CHANGELOG.md` e faça push.

Para publicar uma versão que já tem release (ex.: secrets cadastrados depois): `gh workflow run release.yml -f publish=true`.

## Licença

[MIT](LICENSE)
