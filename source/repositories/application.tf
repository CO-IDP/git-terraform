# Create application repository
resource "github_repository" "application" {
  name        = "application"
  description = "My application"
  visibility  = "public"
}

resource "github_branch_protection" "application" {
  repository_id = github_repository.application.node_id

  pattern          = "main"
  allows_deletions = false
  required_pull_request_reviews {}
}

# Add memberships for application repository
resource "github_team_repository" "application" {
  for_each = {
    for team in local.repo_teams_files["application"] :
    team.team_name => {
      team_id    = github_team.all[team.team_name].id
      permission = team.permission
    } if lookup(github_team.all, team.team_name, false) != false
  }

  team_id    = each.value.team_id
  repository = github_repository.application.id
  permission = each.value.permission
}
