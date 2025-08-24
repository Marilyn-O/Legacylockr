export default function WelcomeScreen() {
  return (
    <div className="welcome-screen min-h-screen flex flex-col items-center justify-center bg-[url('src/assets/bg.png')] bg-cover bg-no-repeat text-white px-4 font-dm">
      <div className="w-3xl text-center flex flex-col items-center gap-4">
        <h1 className="text-7xl font-extrabold mb-4 drop-shadow-lg">
          Welcome to <span className="text-cyan-300 italic">Lockr-UI</span>
        </h1>
        <p className="text-lg mb-8 opacity-90 max-w-xl">
          Your secure vault for managing secrets. Effortlessly store, organize, and protect your sensitive information with confidence.
        </p>
        <a
          href="/dashboard"
          className="inline-block bg-white/40 hover:bg-white hover:text-black text-white font-semibold py-3 px-8 rounded-full shadow ease-out transition duration-200"
        >
          Get Started
        </a>
      </div>
      
    </div>
  );
}