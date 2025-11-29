import axios from "axios";

const instance = axios.create({
  baseURL: "https://bn-dream.site", // تأكد أن نفس البورت المستخدم في Laravel
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
  withCredentials: true, // ✅ هذا مهم جدًا لـ Sanctum
});

// ✅ إضافة Authorization تلقائيًا إذا كان التوكن موجودًا
instance.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default instance;