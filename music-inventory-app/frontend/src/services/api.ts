import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8000',
});

export const getInventory = (search?: string) =>
  api.get('/inventory', { params: search ? { search } : {} });

export const addRecord = (data: any) => api.post('/inventory', data);
export const updateRecord = (serial: number, data: any) =>
  api.put(`/inventory/${serial}`, data);
export const deleteRecord = (serial: number) => api.delete(`/inventory/${serial}`);

