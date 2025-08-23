export default function WelcomeScreen() {
  return (
    <div className="welcome-screen min-h-screen flex flex-col items-center justify-center bg-[url('src/assets/bg.png')] bg-cover bg-no-repeat text-white px-4">
      <div className="max-w-xl text-center">
        <h1 className="text-5xl font-extrabold mb-4 drop-shadow-lg">
          Welcome to <span className="text-purple-400">Lockr-UI</span>
        </h1>
        <p className="text-lg mb-8 opacity-90">
          Your secure vault for managing secrets. Effortlessly store, organize, and protect your sensitive information with confidence.
        </p>
        <a
          href="/dashboard"
          className="inline-block bg-purple-600 hover:bg-purple-700 text-white font-semibold py-3 px-8 rounded-full shadow transition duration-200"
        >
          Get Started
        </a>
      </div>
      <footer className="mt-16 text-sm opacity-70">
        &copy; {new Date().getFullYear()} Lockr-UI. All rights reserved.
      </footer>
    </div>
  );
}