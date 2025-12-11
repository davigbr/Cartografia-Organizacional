#!/usr/bin/env bash
set -uo pipefail

# Diretório base: pasta onde o script está
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="$SCRIPT_DIR"
INDEX_FILE="$VAULT_DIR/index.md"

# Arquivo de saída (pode ser sobrescrito passando como primeiro argumento)
OUTPUT_FILE="${1:-$VAULT_DIR/Cartografia-Organizacional-completo.md}"

echo "Iniciando geração do arquivo compilado..." >&2
echo "Diretório do vault: $VAULT_DIR" >&2
echo "Arquivo de índice: $INDEX_FILE" >&2
echo "Arquivo de saída: $OUTPUT_FILE" >&2

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "ERRO: index.md não encontrado em: $VAULT_DIR" >&2
  exit 1
fi

# Coletar todos os .md do vault (ignorando .obsidian)
echo "Coletando arquivos .md..." >&2
cd "$VAULT_DIR" || exit 1
ALL_MD=()
while IFS= read -r file; do
  [[ -n "$file" ]] && ALL_MD+=("$VAULT_DIR/$file")
done < <(find . -type f -name "*.md" ! -path "*/.obsidian/*" | sort)

echo "Total de arquivos .md encontrados: ${#ALL_MD[@]}" >&2

# Função para extrair título a partir do frontmatter ou nome do arquivo
extract_title() {
  local file="$1"
  local title=""

  if head -n1 "$file" | grep -q '^---[[:space:]]*$'; then
    # Lê frontmatter até a próxima linha ---
    while IFS= read -r line; do
      [[ "$line" =~ ^---[[:space:]]*$ ]] && break
      if [[ "$line" =~ ^title:[[:space:]]*(.*)$ ]]; then
        title="${BASH_REMATCH[1]}"
        # Remove aspas eventuais
        title="${title%\"}"; title="${title#\"}"
        title="${title%\'}"; title="${title#\'}"
      fi
    done < <(tail -n +2 "$file")
  fi

  if [[ -z "$title" ]]; then
    local base
    base="${file##*/}"
    title="${base%.md}"
  fi

  printf '%s\n' "$title"
}

# Monta lista de arquivos na ordem do índice
INCLUDE_ORDER=()

declare -A INCLUDED_MAP=()

# index.md sempre primeiro
INCLUDE_ORDER+=("$INDEX_FILE")
INCLUDED_MAP["$INDEX_FILE"]=1

# Extrair links [[...]] do index.md na ordem
echo "Extraindo links do índice..." >&2
INDEX_LINKS=()
while IFS= read -r link; do
  INDEX_LINKS+=("$link")
done < <(grep -o '\[\[[^]]*\]\]' "$INDEX_FILE" 2>/dev/null | sed 's/\[\[\(.*\)\]\]/\1/' || true)

echo "Total de links encontrados no índice: ${#INDEX_LINKS[@]}" >&2

# Para cada link, procurar arquivo .md com o mesmo nome (basename)
for name in "${INDEX_LINKS[@]}"; do
  # Ignora links vazios
  [[ -z "$name" ]] && continue

  found=""
  for f in "${ALL_MD[@]}"; do
    # Ignora o próprio index e arquivos de saída anteriores
    [[ "$f" == "$INDEX_FILE" ]] && continue
    [[ "$f" == "$OUTPUT_FILE" ]] && continue

    base="${f##*/}"
    base_no_ext="${base%.md}"
    if [[ "$base_no_ext" == "$name" ]]; then
      found="$f"
      break
    fi
  done

  if [[ -n "$found" ]]; then
    # Permite repetições no índice (pode incluir mais de uma vez)
    INCLUDE_ORDER+=("$found")
    INCLUDED_MAP["$found"]=1
  else
    echo "[AVISO] Link no índice sem arquivo correspondente: [[${name}]]" >&2
  fi
done

TOTAL=${#INCLUDE_ORDER[@]}
echo "Total de arquivos a serem incluídos: $TOTAL" >&2

if (( TOTAL == 0 )); then
  echo "ERRO: Nenhum arquivo para incluir." >&2
  exit 1
fi

# Limpa arquivo de saída
echo "Gerando arquivo de saída..." >&2
: > "$OUTPUT_FILE"

# Função de barra de progresso simples
print_progress() {
  local current=$1
  local total=$2
  local width=40

  local progress=$(( current * width / total ))
  local rest=$(( width - progress ))

  local bar
  bar="$(printf '%*s' "$progress" '' | tr ' ' '#')"
  bar+="$(printf '%*s' "$rest" '' | tr ' ' '-')"

  printf '\r[%s] %d/%d' "$bar" "$current" "$total"
}

# Concatenar arquivos na ordem, com título H1
idx=0
for file in "${INCLUDE_ORDER[@]}"; do
  ((idx++))
  print_progress "$idx" "$TOTAL"

  title="$(extract_title "$file")"
  printf '\n# %s\n\n' "$title" >> "$OUTPUT_FILE"
  cat "$file" >> "$OUTPUT_FILE"
  printf '\n\n' >> "$OUTPUT_FILE"

done
printf '\n\nConcluído! Arquivo gerado em: %s\n' "$OUTPUT_FILE" >&2
echo "Tamanho do arquivo: $(wc -c < "$OUTPUT_FILE") bytes" >&2

# Identificar arquivos .md que não foram incluídos
NOT_INCLUDED=()
for f in "${ALL_MD[@]}"; do
  # Ignora index, saída, .obsidian e copilot
  [[ "$f" == "$INDEX_FILE" ]] && continue
  [[ "$f" == "$OUTPUT_FILE" ]] && continue
  [[ "$f" == *"/.obsidian/"* ]] && continue
  [[ "$f" == *"/copilot/"* ]] && continue

  if [[ -z "${INCLUDED_MAP["$f"]+x}" ]]; then
    NOT_INCLUDED+=("$f")
  fi
done

if (( ${#NOT_INCLUDED[@]} > 0 )); then
  echo "\nArquivos .md não incluídos no índice:" >&2
  for f in "${NOT_INCLUDED[@]}"; do
    rel="${f#"$VAULT_DIR/"}"
    echo " - $rel" >&2
  done
else
  echo "\nTodos os arquivos .md relevantes estão no índice." >&2
fi
