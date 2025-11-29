import instance from "./axios"; // 🔴🔴🔴 تم التعديل: استيراد instance
// import axios from "axios"; // 🔴🔴🔴 تم التعليق عليه أو حذفه

// 🔴🔴🔴 تم التعديل: استخدام المسار النسبي
const API_URL = "/api/football-matches";

// 🧩 نوع المباراة
export interface Match {
  id?: number;
  team1: string;
  team2: string;
  date: string;
  time: string;
  channel: string;
  result?: string;
  status: "قادمة" | "جارية" | "منتهية";
}

// 🟢 جلب كل المباريات
export const getMatches = async () => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.get<Match[]>(API_URL);
   return response.data;
};

// 🟢 جلب مباراة واحدة
export const getMatch = async (id: number) => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.get<Match>(`${API_URL}/${id}`);
  return response.data;
};

// 🟢 إنشاء مباراة جديدة
export const createMatch = async (data: Omit<Match, "id">) => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.post(API_URL, data, {
    headers: { "Content-Type": "application/json" },
  });
  return response;
};

// ✏️ تحديث مباراة
export const updateMatch = async (id: number, data: Partial<Match>) => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.post(`${API_URL}/${id}?_method=PUT`, data, {
    headers: { "Content-Type": "application/json" },
  });
  return response;
};

// 🔴 حذف مباراة
export const deleteMatch = async (id: number) => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.delete(`${API_URL}/${id}`);
  return response;
};
