export const dynamic = "force-dynamic";
import { withIikoSession, iikoGetRaw } from "@/lib/iiko";

const FALLBACK = [
  { id: "1239d270-1bbe-f64f-b7ea-5f00518ef508", name: "Основной склад" },
];

export async function GET() {
  try {
    const stores = await withIikoSession(async (token) => {
      const xml = await iikoGetRaw("corporation/stores", token);
      if (!xml) return FALLBACK;

      // XML структура: <corporateItemDtoes><corporateItemDto><id>...</id><name>...</name>...
      const results = [];
      const regex = /<corporateItemDto>([\s\S]*?)<\/corporateItemDto>/g;
      let match;
      while ((match = regex.exec(xml)) !== null) {
        const block = match[1];
        const id = tag(block, "id");
        const name = tag(block, "name");
        const type = tag(block, "type");
        if (id === "1239d270-1bbe-f64f-b7ea-5f00518ef508" && name && type === "STORE") {
          results.push({ id, name });
        }
      }

      return results.length > 0 ? results : FALLBACK;
    });

    return Response.json(stores);
  } catch (e) {
    console.error("[/api/iiko/stores]", e.message);
    return Response.json(FALLBACK);
  }
}

function tag(xml, name) {
  const m = xml.match(new RegExp(`<${name}>([^<]*)</${name}>`));
  return m ? m[1].trim() : "";
}
