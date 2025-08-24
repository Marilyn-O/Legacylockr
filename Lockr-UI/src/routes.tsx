import { createBrowserRouter } from "react-router-dom";
import WelcomeScreen from "./pages/welcome_screen";
import LandingLayout from "./layout/landing";

export const Router = createBrowserRouter([
    {
        path: "/",
        Component: LandingLayout,
        children: [
            {
                index: true,
                Component: WelcomeScreen
            }
        ]
    }
])