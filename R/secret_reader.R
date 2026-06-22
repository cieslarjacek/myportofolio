#' @title Secrets reader
#'
#' @description
#' Reads secrets from the vault.
#'
#' @export
SecretReader <- R6::R6Class(
  classname = "SecretReader",
  private = list(
    # A specific path to secrets inside the vault. Consists of the package name
    # and the environment name.
    .secret_path = NULL,
    # Target vault server network address (URL).
    .vault_address = NULL,
    # Target vault authentication token.
    .vault_token = NULL,
    # Target vault URL endpoint.
    .vault_url = NULL
  ),
  public = list(
    #' @field current_env The environment where the app is deployed and runs.
    current_env = NULL,
    #' @description
    #' Creates a new reader object.
    #'
    #' @param current_env A string containing the name of the environment where
    #'   the app is deployed and runs.
    #' @return A new `SecretReader` object.
    initialize = function(current_env = Sys.getenv("DEPLOYMENT_ENV")) {
      self$current_env <- current_env
      private$.secret_path <- do.call(
        file.path, list("myportfolio", self$current_env)
      )
      private$.vault_address <- Sys.getenv("VAULT_ADDRESS")
      private$.vault_token <- Sys.getenv("VAULT_TOKEN")
      private$.vault_url <- sprintf(
        "%s/v1/secret/data/%s", private$.vault_address, private$.secret_path
      )
    },
    #' @description
    #' Retrieves all secrets from the target vault.
    #'
    #' @return A list of secrets for the current environment.
    get_all_secrets = function() {
      raw_response <- httr2::request(private$.vault_url) %>%
        httr2::req_headers(
          "X-Vault-Token" = private$.vault_token,
          "Content-Type"  = "application/json"
        ) %>%
        httr2::req_error(is_error = \(resp) FALSE) %>%
        httr2::req_perform()

      response_status <- httr2::resp_status(raw_response)

      if (response_status != 200L) {
        stop(sprintf(
          "Vault request failed [%d]: %s",
          response_status,
          httr2::resp_body_string(raw_response)
        ))
      }

      secret_value_list <- raw_response %>%
        httr2::resp_body_json()
      secret_value_list$data$data
    },
    #' @description
    #' Retrieves a single secret value from the target vault.
    #'
    #' @param secret_name A string containing the name of the secret.
    #' @return A secret value.
    get_secret = function(secret_name) {
      secret_value <- self$get_all_secrets()[[secret_name]]

      if (is.null(secret_value)) {
        stop(sprintf(
          "Secret with name '%s' not found at the vault path 'secret/data/%s'.",
          secret_name,
          private$.secret_path
        ))
      }

      secret_value
    }
  )
)
