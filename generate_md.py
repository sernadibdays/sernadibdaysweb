import json
import urllib.request

url = 'https://wrngnleiuwpegupqglqa.supabase.co/rest/v1/packages?select=*,itinerary_days(*),package_tiers(*)&order=sort_order.asc'
api_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndybmdubGVpdXdwZWd1cHFnbHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1ODM4MTksImV4cCI6MjEwNjE1OTgxOX0.Lc9TDAAM4APWLz7AK6u3VQOVPvBixes6JCOF6-277hc'

req = urllib.request.Request(url, headers={'apikey': api_key, 'Authorization': 'Bearer ' + api_key})
try:
    with urllib.request.urlopen(req) as response:
        packages = json.loads(response.read().decode())
        
        md = "# Serandib Days - Tour Packages Evaluation\n\n"
        md += "This document contains the details of all tour packages currently live on the Serandib Days website.\n\n"
        
        for pkg in packages:
            md += f"## {pkg.get('title', 'Unknown')}\n"
            md += f"**Duration:** {pkg.get('duration_days', '?')} Days | **Best Time:** {pkg.get('best_time', '?')}\n\n"
            md += f"**Route:** {pkg.get('route', '?')}\n\n"
            md += f"**Description:**\n{pkg.get('description', '')}\n\n"
            
            md += "### Pricing Tiers\n"
            tiers = pkg.get('package_tiers', [])
            for t in tiers:
                md += f"- **{str(t.get('tier', '')).upper()}**: ${t.get('price_usd', '?')} (Stays: {t.get('stay_details', '?')})\n"
            md += "\n"
            
            md += "### Itinerary\n"
            days = pkg.get('itinerary_days', [])
            days.sort(key=lambda x: x.get('day_number', 0))
            for d in days:
                md += f"**Day {d.get('day_number', '?')}: {d.get('title', '?')}**\n{d.get('description', '')} *(Overnight: {d.get('overnight_location', '?')})*\n\n"
            
            md += "---\n\n"
            
        with open('All_Packages_Evaluation.md', 'w') as f:
            f.write(md)
            
        print("Successfully created All_Packages_Evaluation.md")
except Exception as e:
    print(f"Error fetching data: {e}")
