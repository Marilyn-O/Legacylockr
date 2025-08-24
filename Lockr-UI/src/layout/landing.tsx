import { Outlet } from "react-router-dom"
import Navbar from "../components/landing/navbar"
export default function LandingLayout() {
  return (
    <main className="relative font-dm">
      <header className="fixed top-0 z-50 right-0 left-0 px-10">
        <Navbar />
      </header>
      <Outlet />
    </main>
  )
}
