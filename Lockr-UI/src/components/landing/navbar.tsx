import { Link } from "react-router-dom";
import { Button } from "../ui/button";

const linkData = [
    { name: "Home", href: "/" },
    { name: "Features", href: "/features" },
    { name: "About", href: "/about" },
]

export default function Navbar() {
  return (
    <nav className="flex justify-center mt-8">
      <div className="backdrop-blur-md bg-white/30 border border-white/40 rounded-full shadow-lg pl-8 pr-4 py-3 flex gap-3">
        <ul className="flex items-center space-x-8 text-white font-medium">
          {linkData.map((link) => (
            <li key={link.name} className="group flex flex-col items-center">
              <Link
                to={link.href}
                className="hover:text-cyan-100 transition-colors duration-200"
              >
                {link.name}
              </Link>
              <span className="w-0 bg-amber-200 group-hover:w-full group-hover:border-b-1 transition-all duration-200 ease-out"></span>
            </li>
          ))}
        </ul>
        <div className="ml-8 inline-block align-middle">
            <Button variant="outline" size="sm" className="rounded-full cursor-pointer py-4">
                connect wallet
            </Button>
        </div>
      </div>
    </nav>
  );
}
