import instance from "./axios"; // تم التأكد من أن المسار الصحيح هو "./axios"

const API_URL = "/api/rooms";

export interface Room {
  id: number;
  category: string;
  name: string;
  price: number;
  capacity: number;
  status: string;
  description: string;
  features: string[];
  image_path?: string;
}

// 🟢 جلب كل الغرف
export const getRooms = async (): Promise<Room[]> => {
  const { data } = await instance.get(API_URL);
  return data;
};

// 🟢 تحديث الغرفة
export const updateRoom = async (id: number, formData: FormData) => {
  // 🔴🔴🔴 تم إزالة headers
  return await instance.post(`${API_URL}/${id}?_method=PUT`, formData);
};

// 🟢 إنشاء غرفة
export const createRoom = async (formData: FormData) => {
  // 🔴🔴🔴 تم إزالة headers
  return await instance.post(API_URL, formData);
};

// 🟢 حذف غرفة
export const deleteRoom = async (id: number) => {
  return await instance.delete(`${API_URL}/${id}`);
};
