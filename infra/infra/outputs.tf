output "codepipeline_frontend_arn" {
    value = module.carshub_frontend_codepipeline.arn
}

output "codepipeline_backend_arn" {
    value = module.carshub_backend_codepipeline.arn
}