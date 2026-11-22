import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import AdminApp from './AdminApp'
import './styles.css'
const isAdminRoute = window.location.pathname.replace(/\/+$/,'') === '/admin'
if (isAdminRoute) {
  document.title = 'Acceso privado | World Tree Shop'
  let robots = document.querySelector<HTMLMetaElement>('meta[name="robots"]')
  if (!robots) {
    robots = document.createElement('meta')
    robots.name = 'robots'
    document.head.appendChild(robots)
  }
  robots.content = 'noindex, nofollow'
}
const Root = isAdminRoute ? AdminApp : App
createRoot(document.getElementById('root')!).render(<React.StrictMode><Root /></React.StrictMode>)
