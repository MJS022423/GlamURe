import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import Navigate from './Navigate'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <Navigate />
  </StrictMode>,
)
