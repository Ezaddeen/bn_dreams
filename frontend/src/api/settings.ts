import instance from "./axios"; // 🔴🔴🔴 تم التعديل: استيراد instance
import { AxiosResponse } from "axios";

// 🔴🔴🔴 تم التعديل: استخدام المسار النسبي
const API_URL = "/api/settings"; 

// ===============================
// 🔹 واجهة بيانات الإعدادات العامة
// ===============================
export interface Settings {
  siteName?: string;
  logo?: File | string;
  // مرونة للحقول الإضافية
  [key: string]: string | number | boolean | File | null | undefined;
}

// ===============================
// 🔹 جلب الإعدادات
// ===============================
export const getSettings = async (): Promise<AxiosResponse<Settings>> => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  return instance.get<Settings>(API_URL);
};

// ===============================
// 🔹 تحديث الإعدادات
// ===============================
export const updateSettings = async (
  formData: FormData
): Promise<AxiosResponse<Settings>> => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  return instance.post<Settings>(API_URL, formData, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
};
