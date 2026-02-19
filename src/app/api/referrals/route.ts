import { randomUUID } from 'crypto';
import { NextRequest, NextResponse } from 'next/server';
import { getAuthContext, getSupabaseServerClient } from '@/lib/supabase';

const INTAKE_PATHS = new Set(['referral', 'direct_engagement']);
const SOURCE_TYPES = new Set(['employee_self', 'manager', 'coordinator', 'hr', 'anonymous_other']);
const RISK_LEVELS = new Set(['low', 'medium', 'high', 'critical']);

export async function POST(req: NextRequest) {
  try {
    const auth = getAuthContext(req.headers.get('authorization'));
    const body = await req.json();

    const required = ['intake_path', 'source_type', 'employee_id', 'risk_level', 'support_category_codes'];
    for (const key of required) {
      if (!(key in body)) return NextResponse.json({ detail: 'Missing required fields' }, { status: 400 });
    }

    if (!INTAKE_PATHS.has(body.intake_path) || !SOURCE_TYPES.has(body.source_type) || !RISK_LEVELS.has(body.risk_level)) {
      return NextResponse.json({ detail: 'Invalid intake/source/risk enum' }, { status: 400 });
    }

    if (!Array.isArray(body.support_category_codes) || body.support_category_codes.length === 0) {
      return NextResponse.json({ detail: 'support_category_codes must be a non-empty array' }, { status: 400 });
    }

    const supabase = getSupabaseServerClient();
    const { data: employee, error: employeeError } = await supabase
      .from('employees')
      .select('id, tenant_id')
      .eq('id', body.employee_id)
      .maybeSingle();

    if (employeeError) return NextResponse.json({ detail: employeeError.message }, { status: 500 });
    if (!employee) return NextResponse.json({ detail: 'Employee not found' }, { status: 404 });
    if (employee.tenant_id !== auth.tenantId) return NextResponse.json({ detail: 'Cross-tenant access denied' }, { status: 403 });

    const referralId = randomUUID();
    const { error } = await supabase.from('referrals').insert({
      id: referralId,
      tenant_id: auth.tenantId,
      intake_path: body.intake_path,
      source_type: body.source_type,
      employee_id: body.employee_id,
      referral_status: 'submitted',
      risk_level: body.risk_level,
      support_category_codes: body.support_category_codes,
      submitted_by_user_id: auth.userId,
      assigned_coordinator_id: body.assigned_coordinator_id ?? null,
      submitted_at: new Date().toISOString(),
    });

    if (error) return NextResponse.json({ detail: error.message }, { status: 500 });
    return NextResponse.json({ id: referralId, referral_status: 'submitted' });
  } catch {
    return NextResponse.json({ detail: 'Invalid token or JSON body' }, { status: 401 });
  }
}
