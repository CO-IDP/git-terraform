# Create local values to retrieve items from JSON
locals {

  # Parse repo team membership files
  repo_teams_path = "datasets/repos-teams"
  repo_teams_files = {
    for file in fileset(local.repo_teams_path, "*.json") :
    trimsuffix(file, ".json") => jsondecode(file("${local.repo_teams_path}/${file}"))
  }

  # Parse team member files
  team_members_path = "datasets/team-members"
  team_members_files = {
    for file in fileset(local.team_members_path, "*.json") :
    trimsuffix(file, ".json") => jsondecode(file("${local.team_members_path}/${file}"))
  }

  # Create temp object that has team ID and JSON contents - (known after apply)
  team_members_temp = flatten([
    for team, members in local.team_members_files : [
      for tn, t in github_team.all : {
        name    = t.name
        id      = t.id
        slug    = t.slug
        members = members
      } if t.slug == team
    ]
  ])

  # Create object for each team-member relationship - (known after apply)
  team_members = flatten([
    for team in local.team_members_temp : [
      for member in team.members : {
        name     = "${team.slug}-${member.username}"
        team_id  = team.id
        username = member.username
        role     = member.role
      }
    ]
  ])
}
