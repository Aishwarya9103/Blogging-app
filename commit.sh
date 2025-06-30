#!/bin/bash

# Time window
SINCE="2025-02-01"
UNTIL="2025-02-28"

# Optional: GitHub private repo access (only needed for remote fetch)
#GIT_USERNAME="your_username"
#GIT_TOKEN="your_token"
#REPO_URL="https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/<org_or_user>/<repo>.git"
REPO_URL="https://github.com/Aishwarya9103/Blogging-app.git"
OUTPUT_FILE="git_branch_commit_stats_may.csv"

echo "Branch,Commits,Merges" > "$OUTPUT_FILE"


if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Not a Git repository!"
  exit 1
fi


#Fetch latest (optional for private repos)
git fetch "$REPO_URL" --all --quiet --prune

# Header
echo ""
echo "Branch-wise Commit and Merge Stats (from $SINCE to $UNTIL):"
echo "---------------------------------------------------------------"
printf "%-40s %-10s %-10s\n" "Branch" "Commits" "Merges"
echo "---------------------------------------------------------------"


branches=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes | grep -vE 'origin/HEAD|^\s*$')


for branch in $branches; do
  
  if ! git show-ref --verify --quiet "refs/heads/$branch" && ! git show-ref --verify --quiet "refs/remotes/$branch"; then
    continue
  fi

 
  total_commits=$(git log "$branch" --first-parent --since="$SINCE" --until="$UNTIL" --pretty=oneline 2>/dev/null | wc -l)

  
  total_merges=$(git log "$branch" --first-parent --since="$SINCE" --until="$UNTIL" --merges --pretty=oneline 2>/dev/null | wc -l)

  printf "%-40s %-10s %-10s\n" "$branch" "$total_commits" "$total_merges"
  echo "$branch,$total_commits,$total_merges" >> "$OUTPUT_FILE"


  authors=$(git log "$branch" --first-parent --since="$SINCE" --until="$UNTIL" --pretty='%an' 2>/dev/null | sort | uniq)

  for author in $authors; do
    author_commits=$(git log "$branch" --first-parent --since="$SINCE" --until="$UNTIL" --pretty='%an' 2>/dev/null | grep -F "$author" | wc -l)
    author_merges=$(git log "$branch" --first-parent --since="$SINCE" --until="$UNTIL" --merges --pretty='%an' 2>/dev/null | grep -F "$author" | wc -l)
    printf "  %-38s %-10s %-10s\n" "$author" "$author_commits" "$author_merges"
        echo "$author,$author_commits,$author_merges" >> "$OUTPUT_FILE"
  done

  echo "" >> "$OUTPUT_FILE"

done
echo "CSV report saved to: $OUTPUT_FILE"
echo "---------------------------------------------------------------"
 
