const fs = require('fs');

const url = 'https://wrngnleiuwpegupqglqa.supabase.co/rest/v1/packages?select=*,itinerary_days(*),package_tiers(*)&order=sort_order.asc';
const apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndybmdubGVpdXdwZWd1cHFnbHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1ODM4MTksImV4cCI6MjEwNjE1OTgxOX0.Lc9TDAAM4APWLz7AK6u3VQOVPvBixes6JCOF6-277hc';

async function generate() {
    const res = await fetch(url, {
        headers: {
            'apikey': apiKey,
            'Authorization': 'Bearer ' + apiKey
        }
    });
    
    if (!res.ok) {
        console.error("Failed to fetch", await res.text());
        return;
    }
    
    const packages = await res.json();
    let md = "# Serandib Days - Tour Packages Evaluation\n\n";
    md += "This document contains the details of all tour packages currently live on the Serandib Days website.\n\n";
    
    for (const pkg of packages) {
        md += `## ${pkg.title}\n`;
        md += `**Duration:** ${pkg.duration_days} Days | **Best Time:** ${pkg.best_time}\n\n`;
        md += `**Route:** ${pkg.route}\n\n`;
        md += `**Description:**\n${pkg.description}\n\n`;
        
        md += `### Pricing Tiers\n`;
        const tiers = pkg.package_tiers || [];
        tiers.forEach(t => {
            md += `- **${t.tier.toUpperCase()}**: $${t.price_usd} (Stays: ${t.stay_details})\n`;
        });
        md += `\n`;
        
        md += `### Itinerary\n`;
        let days = pkg.itinerary_days || [];
        days.sort((a,b) => a.day_number - b.day_number);
        days.forEach(d => {
            md += `**Day ${d.day_number}: ${d.title}**\n${d.description} *(Overnight: ${d.overnight_location})*\n\n`;
        });
        
        md += `---\n\n`;
    }
    
    fs.writeFileSync('All_Packages_Evaluation.md', md);
    console.log("Successfully created All_Packages_Evaluation.md");
}

generate();
