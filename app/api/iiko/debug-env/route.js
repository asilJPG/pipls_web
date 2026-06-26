export const dynamic = "force-dynamic";

export async function GET() {
  const obfuscate = (str) => {
    if (!str) return "NOT_SET";
    if (str.length <= 10) return "***";
    return `${str.substring(0, 15)}...${str.substring(str.length - 5)}`;
  };

  return Response.json({
    IIKO_SERVER: obfuscate(process.env.IIKO_SERVER),
    IIKO_WEB_URL: obfuscate(process.env.IIKO_WEB_URL),
    IIKO_LOGIN: process.env.IIKO_LOGIN || "NOT_SET",
    IIKO_WEB_LOGIN: process.env.IIKO_WEB_LOGIN || "NOT_SET",
    NODE_ENV: process.env.NODE_ENV,
  });
}
