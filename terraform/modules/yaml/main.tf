data "external" "yaml2json" {
  program = ["ruby", "${path.module}/yaml2json.rb", "${var.path}"]
}
