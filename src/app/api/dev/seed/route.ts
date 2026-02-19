import { NextRequest, NextResponse } from 'next/server';
import { getAuthContext, getSupabaseServerClient } from '@/lib/supabase';

export async function POST(req: NextRequest) {
  try {
    const auth = getAuthContext(req.headers.get('authorization'));
    const supabase = getSupabaseServerClient();

    const users = [
      { id: 'u-admin', tenant_id: auth.tenantId, email: 'admin@example.com', role: 'company_admin' },
      { id: 'u-coord', tenant_id: auth.tenantId, email: 'coord@example.com', role: 'coordinator' },
      { id: 'u-manager', tenant_id: auth.tenantId, email: 'manager@example.com', role: 'manager' },
    ];

    const employees = [
      { id: 'e-1', tenant_id: auth.tenantId, first_name: 'Ava', last_name: 'Reed', email: 'ava@example.com' },
      { id: 'e-2', tenant_id: auth.tenantId, first_name: 'Noah', last_name: 'Cole', email: 'noah@example.com' },
    ];

    const { error: userError } = await supabase.from('users').upsert(users, { onConflict: 'id' });
    if (userError) return NextResponse.json({ detail: userError.message }, { status: 500 });

    const { error: employeeError } = await supabase.from('employees').upsert(employees, { onConflict: 'id' });
    if (employeeError) return NextResponse.json({ detail: employeeError.message }, { status: 500 });

    return NextResponse.json({ users: users.length, employees: employees.length });
  } catch {
    return NextResponse.json({ detail: 'Invalid token' }, { status: 401 });
  }
}
