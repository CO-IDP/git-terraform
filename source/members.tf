resource "github_membership" "all" {
  for_each = {
    for member in jsondecode(file("datasets/members.json")) :
    member.username => member
  }

  username = each.value.username
  role     = each.value.role
}