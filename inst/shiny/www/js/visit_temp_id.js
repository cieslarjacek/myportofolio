// Manage unique and temporary visit/user ID cookie.
;(function () {
  // Check if ID cookie value already exists.
  function getCookie (cookie_name) {
    var match = document.cookie.match(
      new RegExp('(^| )' + cookie_name + '=([^;]+)')
    )
    return match ? match[2] : null
  }

  // Create and store new ID cookie.
  if (!getCookie('visit_id')) {
    var id = crypto.randomUUID
      ? crypto.randomUUID()
      : Date.now() + '-' + Math.random().toString(36).slice(2)
    document.cookie =
      'visit_id=' + id + '; path=/; SameSite=Lax'
  }
})()
