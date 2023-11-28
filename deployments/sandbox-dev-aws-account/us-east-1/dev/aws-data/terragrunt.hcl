terraform {
  source  = "${dirname(find_in_parent_folders())}/..//infrastructure/modules/aws-data"
}
include {
  path = find_in_parent_folders()
}
inputs = {

}
