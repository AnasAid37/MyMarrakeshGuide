import { connection } from "next/server";
import { LandingPage } from "@/components/landing-page";

export default async function HomePage() {
  await connection();
  return <LandingPage />;
}
