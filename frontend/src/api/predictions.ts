import instance from "./axios"; // 🔴🔴🔴 تم التعديل: استخدام المسار الصحيح "./axios"

// 🔹 عنوان الـ API
const API_URL = "/api/predictions"; // 🔴🔴🔴 تم التعديل: استخدام المسار النسبي

// 🔹 أنواع البيانات
export interface PredictionData {
  user_id: number;
  match_id: number; // ← هذا فقط لسهولة الاستخدام في الواجهة
  team1: number;
  team2: number;
}

export interface PredictionResponse {
  id: number;
  user_id: number;
  football_match_id: number;
  team1_score: number;
  team2_score: number;
  points: number | null;
  created_at: string;
  updated_at: string;
  match?: {
    id: number;
    team1: string;
    team2: string;
    date: string;
    time: string;
  };
}

export interface LeaderboardItem {
  user_id: number;
  total_points: number;
  user?: {
    name: string;
  };
}

/**
 * 🟢 إرسال توقع جديد أو تحديث موجود
 * يتوافق مع Laravel (PredictionController@store)
 */
export const postPrediction = async (data: PredictionData) => {
  const payload = {
    user_id: data.user_id,
    football_match_id: data.match_id, // ✅ مطابق للـ backend
    team1_score: data.team1,          // ✅ مطابق
    team2_score: data.team2,          // ✅ مطابق
  };

  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.post(API_URL, payload);
  return response.data as { message: string; data: PredictionResponse };
};

/**
 * 🟢 جلب جميع توقعات المستخدم
 * GET /api/predictions/user/{userId}
 */
export const getUserPredictions = async (userId: number) => {
  if (!userId) return []; // ✅ حماية إضافية
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.get(`${API_URL}/user/${userId}`);
  return Array.isArray(response.data) ? response.data : [];
};

/**
 * 🏆 جلب قائمة المتصدرين
 * GET /api/predictions/leaderboard
 */
export const getLeaderboard = async () => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const response = await instance.get(`${API_URL}/leaderboard`);
  return Array.isArray(response.data) ? response.data : [];
};
