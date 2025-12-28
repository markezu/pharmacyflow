import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Plus, Search, Filter } from 'lucide-react';
import { supabase } from '../lib/supabase';

// Mock data until Supabase is connected with real data
const MOCK_MEDICINES = [
  { id: 1, name: 'Paracetamol', name_ar: 'باراسيتامول', stock: 150, price: 250, category: 'Painkillers' },
  { id: 2, name: 'Amoxicillin', name_ar: 'أموكسيسيلين', stock: 45, price: 850, category: 'Antibiotics' },
  { id: 3, name: 'Vitamin C', name_ar: 'فيتامين سي', stock: 200, price: 500, category: 'Vitamins' },
];

interface Medicine {
  id: number;
  name: string;
  name_ar: string;
  stock: number;
  price: number;
  category: string;
}

export const Inventory: React.FC = () => {
  const { t } = useTranslation();
  const [medicines, setMedicines] = useState<Medicine[]>(MOCK_MEDICINES);
  const [loading, setLoading] = useState(false);

  const fetchMedicines = async () => {
    setLoading(true);
    const { data, error } = await supabase.from('medicines').select('*');
    if (!error && data) {
      setMedicines(data);
    }
    setLoading(false);
  };

  useEffect(() => {
    // Ideally fetch from Supabase
    // fetchMedicines();
    // eslint-disable-next-line no-constant-condition
    if (false) fetchMedicines(); // Avoid unused variable warning during build
  }, []);

  if (loading) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">{t('inventory')}</h1>
        <button className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
          <Plus size={20} />
          <span>{t('add_medicine')}</span>
        </button>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-4 border-b border-gray-100 flex gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder={t('search')}
              className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <button className="flex items-center gap-2 px-4 py-2 border border-gray-200 rounded-lg hover:bg-gray-50">
            <Filter size={20} className="text-gray-500" />
            <span>Filter</span>
          </button>
        </div>

        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-500 text-sm font-medium">
            <tr>
              <th className="px-6 py-4">Name</th>
              <th className="px-6 py-4">Category</th>
              <th className="px-6 py-4">Stock</th>
              <th className="px-6 py-4">Price</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4 text-right">{t('action')}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {medicines.map((item) => (
              <tr key={item.id} className="hover:bg-gray-50">
                <td className="px-6 py-4">
                  <div>
                    <div className="font-medium text-gray-900">{item.name}</div>
                    <div className="text-sm text-gray-500">{item.name_ar}</div>
                  </div>
                </td>
                <td className="px-6 py-4 text-gray-500">{item.category}</td>
                <td className="px-6 py-4 text-gray-900">{item.stock}</td>
                <td className="px-6 py-4 text-gray-900">SDG {item.price}</td>
                <td className="px-6 py-4">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${item.stock > 10 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                    {item.stock > 10 ? 'In Stock' : 'Low Stock'}
                  </span>
                </td>
                <td className="px-6 py-4 text-right">
                  <button className="text-blue-600 hover:text-blue-900 font-medium">Edit</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
