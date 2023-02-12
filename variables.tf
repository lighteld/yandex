variable "yandex_token" {
  description = "Токен для яндекса"
  // Тип значения переменной
  type = string
  // Значение по умолчанию, которое используется если не задано другое
  // default = "yandex"
  // Прячет значение переменной из всех выводов
  // По умолчанию false
  sensitive = true
}
