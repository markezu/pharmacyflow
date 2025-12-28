import React from 'react';
import { useTranslation } from 'react-i18next';
import { DollarSign, Package, TrendingUp, AlertTriangle, type LucideIcon } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string;
  icon: LucideIcon;
  color: string;
  trend: string;
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon: Icon, color, trend }) => (
  <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
    <div className="flex items-center justify-between">
      <div>
        <p className="text-sm text-gray-500 mb-1">{title}</p>
        <h3 className="text-2xl font-bold text-gray-900">{value}</h3>
      </div>
      <div className={`p-3 rounded-lg ${color}`}>
        <Icon size={24} className="text-white" />
      </div>
    </div>
    <div className="mt-4 flex items-center text-sm">
      <span className="text-green-500 font-medium">{trend}</span>
      <span className="text-gray-400 mx-2">vs last month</span>
    </div>
  </div>
);

export const Dashboard: React.FC = () => {
  const { t } = useTranslation();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">{t('dashboard')}</h1>
        <div className="text-sm text-gray-500">
          {new Date().toLocaleDateString('ar-SD', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Sales"
          value="SDG 124,500"
          icon={DollarSign}
          color="bg-blue-500"
          trend="+12%"
        />
        <StatCard
          title="Total Orders"
          value="450"
          icon={Package}
          color="bg-purple-500"
          trend="+5%"
        />
        <StatCard
          title="Growth"
          value="23%"
          icon={TrendingUp}
          color="bg-green-500"
          trend="+2%"
        />
        <StatCard
          title="Low Stock"
          value="12 Items"
          icon={AlertTriangle}
          color="bg-orange-500"
          trend="-3"
        />
      </div>

      {/* Placeholder for Recent Activity or Charts */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 h-96 flex items-center justify-center text-gray-400">
        Chart Placeholder
      </div>
    </div>
  );
};
