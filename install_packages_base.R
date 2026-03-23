options(repos = c(CRAN = Sys.getenv("CRAN_REPO", unset = "https://cloud.r-project.org")))

# Pacotes "pesados" que demoram para compilar
packages <- c(
  "kernlab",
  "caret",
  "fastshap",
  "dplyr",
  "ggfittext",
  "gggenes", 
  "shapviz",
  "randomForest"
  # Adicione aqui outros pacotes genéricos que você sempre usa
)

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    message(paste(">> Instalando:", pkg))
    install.packages(pkg, dependencies = FALSE)
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      stop(paste("❌ Falha ao instalar:", pkg))
    }
  }
}
message("✅ Base image packages ready!")