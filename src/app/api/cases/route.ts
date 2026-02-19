import { randomUUID } from 'crypto';
import { NextRequest, NextResponse } from 'next/server';
import { getAuthContext, getSupabaseServerClient } from '@/lib/supabase';

export async function POST(req: NextRequest) {
  try {
    const auth = getAuthContext(req.headers.get('authorization'));
    const body = await req.json();

    if (!body.employee_id || !body.assigned_coordinator_id) {
      return NextResponse.json({ detail: 'Missing required fields' }, { status: 400 });
    }

    const supabase = getSupabaseServerClient();

    const { data: employee } = await supabase.from('employees').select('id, tenant_id').eq('id', body.employee_id).maybeSingle();
    if (!employee) return NextResponse.json({ detail: 'Employee not found' }, { status: 404 });
    if (employee.tenant_id !== auth.tenantId) return NextResponse.json({ detail: 'Cross-tenant access denied' }, { status: 403 });

    if (body.referral_id) {
      const { data: referral } = await supabase.from('referrals').select('id, tenant_id, employee_id').eq('id', body.referral_id).maybeSingle();
      if (!referral) return NextResponse.json({ detail: 'Referral not found' }, { status: 404 });
      if (referral.tenant_id !== auth.tenantId) return NextResponse.json({ detail: 'Cross-tenant access denied' }, { status: 403 });
      if (referral.employee_id !== body.employee_id) return NextResponse.json({ detail: 'Referral/employee mismatch' }, { status: 400 });

      await supabase
        .from('referrals')
        .update({ referral_status: 'converted_to_case', first_response_at: new Date().toISOString() })
        .eq('id', body.referral_id);
    }

    const caseId = randomUUID();
    const { error } = await supabase.from('cases').insert({
      id: caseId,
      tenant_id: auth.tenantId,
      employee_id: body.employee_id,
      referral_id: body.referral_id ?? null,
      assigned_coordinator_id: body.assigned_coordinator_id,
      case_status: 'open',
      opened_at: new Date().toISOString(),
    });

    if (error) return NextResponse.json({ detail: error.message }, { status: 500 });
    return NextResponse.json({ id: caseId, case_status: 'open' });
  } catch {
    return NextResponse.json({ detail: 'Invalid token or JSON body' }, { status: 401 });
  }
}
