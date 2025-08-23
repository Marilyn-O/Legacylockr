import { createBrowserRouter } from "react-router-dom";
import WelcomeScreen from "./pages/welcome_screen";

export const Router = createBrowserRouter([
    {
        path: "/",
        element: <WelcomeScreen />,
    }
])