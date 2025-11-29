import instance from "./axios"; // 🔴🔴🔴 تم التعديل: استيراد instance
// import axios from "axios"; // 🔴🔴🔴 تم التعليق عليه أو حذفه

// 🔴🔴🔴 تم التعديل: استخدام المسار النسبي
const API_URL = "/api/notifications";

// 🔹 إعداد التوكن مرة واحدة
const authHeaders = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem("token")}`,
  },
});

// ✅ جلب جميع الإشعارات
export const getNotifications = async () => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const res = await instance.get(API_URL, authHeaders());
  return res.data;
};

// ✅ جلب الإشعارات غير المقروءة فقط
export const getUnreadNotifications = async () => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const res = await instance.get(`${API_URL}/unread`, authHeaders());
  return res.data;
};

// ✅ تحديد إشعار كمقروء
export const markNotificationAsRead = async (id: string) => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const res = await instance.post(`${API_URL}/${id}/read`, {}, authHeaders());
  return res.data;
};

// ✅ حذف إشعار واحد
export const deleteNotification = async (id: string) => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const res = await instance.delete(`${API_URL}/${id}`, authHeaders());
  return res.data;
};

// ✅ حذف جميع الإشعارات
export const clearAllNotifications = async () => {
  // 🔴🔴🔴 تم التعديل: استخدام instance
  const res = await instance.delete(API_URL, authHeaders());
  return res.data;
};
