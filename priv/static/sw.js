// ShareCircle service worker — handles web push notifications.

self.addEventListener("push", event => {
  if (!event.data) return

  let data = {}
  try { data = event.data.json() } catch (_) { data = {title: "ShareCircle", body: event.data.text()} }

  const title = data.title || "ShareCircle"
  const options = {
    body: data.body || "",
    icon: "/images/logo.png",
    badge: "/images/logo.png",
    data: data.data || {},
    tag: data.tag || "sharecircle",
  }

  event.waitUntil(self.registration.showNotification(title, options))
})

self.addEventListener("notificationclick", event => {
  event.notification.close()
  const url = event.notification.data.url || "/"
  event.waitUntil(
    clients.matchAll({type: "window", includeUncontrolled: true}).then(list => {
      const existing = list.find(c => c.url.includes(self.location.origin) && "focus" in c)
      if (existing) return existing.focus()
      return clients.openWindow(url)
    })
  )
})
