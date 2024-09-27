import streamlit as st
import matplotlib.pyplot as plt
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime
import pandas as pd
import folium
from streamlit_folium import folium_static


st.set_page_config(
    layout="wide", 
    page_title="Flood Risk Analysis and Response Management System",
    page_icon="🌊",
)

DATABASE_URL = "mysql+pymysql://root:@localhost/flood_risk_db2"
engine = create_engine(DATABASE_URL)

def add_flood_report(upazilla, needs, contact, location_details, source, flood_zone):
    try:
        with engine.begin() as connection:
            query = text("""
                INSERT INTO flood_reports (upazilla, needs, contact_details, location_details, source, status, flood_zone) 
                VALUES (:upazilla, :needs, :contact, :location_details, :source, 'Processing', :flood_zone)
            """)
            connection.execute(query, {
                'upazilla': upazilla, 
                'needs': needs, 
                'contact': contact, 
                'location_details': location_details, 
                'source': source,
                'flood_zone': flood_zone
            })
        return True
    except Exception as e:
        st.error(f"An error occurred while submitting the report: {e}")
        return False

def fetch_flood_reports(status_filter=None, zone_filter="All"):
    try:
        with engine.connect() as connection:
            if zone_filter == "All":
                if status_filter:
                    query = text("SELECT * FROM flood_reports WHERE status = :status_filter")
                    result = connection.execute(query, {'status_filter': status_filter})
                else:
                    query = text("SELECT * FROM flood_reports")
                    result = connection.execute(query)
            else:
                if status_filter:
                    query = text("SELECT * FROM flood_reports WHERE flood_zone = :zone_filter AND status = :status_filter")
                    result = connection.execute(query, {'zone_filter': zone_filter, 'status_filter': status_filter})
                else:
                    query = text("SELECT * FROM flood_reports WHERE flood_zone = :zone_filter")
                    result = connection.execute(query, {'zone_filter': zone_filter})
            return result.fetchall()
    except Exception as e:
        st.error(f"An error occurred while fetching flood reports: {e}")
        return []

def delete_flood_report(report_id):
    try:
        with engine.begin() as connection:
            query = text("DELETE FROM flood_reports WHERE id = :id")
            connection.execute(query, {'id': report_id})
        return True
    except Exception as e:
        st.error(f"An error occurred while deleting the report: {e}")
        return False

def mark_as_resolved(report_id):
    try:
        with engine.begin() as connection:
            query = text("UPDATE flood_reports SET status = 'Resolved' WHERE id = :id")
            connection.execute(query, {'id': report_id})
        return True
    except Exception as e:
        st.error(f"An error occurred while marking the report as resolved: {e}")
        return False

def add_response_action(report_id, action_taken, response_by):
    try:
        with engine.begin() as connection:
            query = text("""
                INSERT INTO response_actions (report_id, action_taken, response_by)
                VALUES (:report_id, :action_taken, :response_by)
            """)
            connection.execute(query, {
                'report_id': report_id, 
                'action_taken': action_taken,
                'response_by': response_by
            })
        return True
    except Exception as e:
        st.error(f"An error occurred while logging the response action: {e}")
        return False

def get_total_donations():
    query = text("SELECT SUM(amount) FROM donations;")
    try:
        with engine.connect() as connection:
            result = connection.execute(query)
            total_amount = result.scalar()
        return total_amount if total_amount is not None else 0
    except Exception as e:
        st.error(f"An error occurred while fetching total donations: {e}")
        return 0

def add_donation(donation_type, amount, donor_name):
    query = text("""
        INSERT INTO donations (type, amount, donor_name)
        VALUES (:type, :amount, :donor_name);
    """)
    try:
        with engine.begin() as connection:
            connection.execute(query, {
                'type': donation_type,
                'amount': amount,
                'donor_name': donor_name
            })
        return "Donation added successfully!"
    except SQLAlchemyError as e:
        return f"An error occurred: {str(e)}"

def fetch_evacuation_centers():
    try:
        with engine.connect() as connection:
            query = text("""
                SELECT center_id, location, capacity, current_occupancy, location_id
                FROM evacuation_centers
                ORDER BY center_id
            """)
            result = connection.execute(query)
            return result.fetchall()
    except Exception as e:
        st.error(f"An error occurred while fetching evacuation centers: {e}")
        return []

def fetch_available_volunteers():
    try:
        with engine.connect() as connection:
            query = text("SELECT volunteer_id FROM volunteers WHERE availability = 'Available'")  
            result = connection.execute(query)
            return result.fetchall()
    except Exception as e:
        st.error(f"An error occurred while fetching volunteers: {e}")
        return []

def plot_flood_zones():
    reports = fetch_flood_reports()  # Fetch all flood reports
    if reports:  # Check if reports are fetched successfully
        df = pd.DataFrame(reports)  # Create DataFrame from fetched reports

        df.columns = ['ID', 'Upazilla', 'Needs', 'Contact', 'Location', 'Source', 'Status', 'Flood Zone', 'Extra Column 1', 'Extra Column 2', 'Extra Column 3']  # Adjust as needed

        # Create a map centered on Bangladesh using correct latitude and longitude
        map_bangladesh = folium.Map(location=[23.685, 90.3563], zoom_start=7)  # Add longitude value

        flood_zones = {
            "Zone 1": [23.8103, 90.4125],  # Example coordinates
            "Zone 2": [22.3569, 91.7832],
            "Zone 3": [24.2478, 91.2476],
            "Zone 4": [23.6850, 90.2750],
            "Zone 5": [24.3662, 88.6177]
        }

        report_counts = df['Flood Zone'].value_counts().to_dict()
        for zone, coords in flood_zones.items():
            count = report_counts.get(zone, 0)
            color = 'green' if count == 0 else 'red'
            folium.CircleMarker(
                location=coords,
                radius=10,
                color=color,
                fill=True,
                fill_opacity=0.6,
                popup=f"{zone}: {count} reports"
            ).add_to(map_bangladesh)

        folium_static(map_bangladesh)
    else:
        st.write("No flood reports available for visualization.")


st.sidebar.title("Navigation")
page = st.sidebar.radio("Select a page:", ["Dashboard", "Evacuation Centers", "Response Actions", "Donations Management", "Volunteer Management"])

if page == "Dashboard":
    st.title("🌊 Flood Risk Analysis and Response Management System")
    st.markdown("Track flood reports, responses, and zones for effective flood management.")
    col1, col2 = st.columns(2)

    with col1:
        st.header("Submit a Flood Report")
        with st.form("flood_report_form"):
            bangladesh_upazillas = [
                'Dhaka', 'Chattogram', 'Sylhet', 'Rajshahi', 'Barishal', 'Khulna', 'Rangpur', 
                'Mymensingh', 'Narayanganj', 'Gazipur', 'Comilla', 'Jessore', 'Feni', 'Nawabganj',
                'Bogra', 'Dinajpur', 'Jamalpur', 'Pabna', 'Tangail', 'Faridpur'
            ]
            upazilla = st.selectbox("Upazilla Name", bangladesh_upazillas)
            needs = st.text_input("Needs (e.g., Relief, Food)")
            contact = st.text_input("Contact Details")
            location_details = st.text_area("Location Details")
            source = st.text_input("Source (e.g., URL, Journalist Name)")
            flood_zone = st.selectbox("Flood Zone", ["Zone 1", "Zone 2", "Zone 3", "Zone 4", "Zone 5"])

            submit_button = st.form_submit_button("Submit Report")
            if submit_button:
                if upazilla and needs and contact and location_details and source and flood_zone:
                    success = add_flood_report(upazilla, needs, contact, location_details, source, flood_zone)
                    if success:
                        st.success("Report submitted successfully.")
                        st.experimental_rerun()
                    else:
                        st.error("Failed to submit report.")
                else:
                    st.error("Please fill out all required fields.")

        st.header("Resolved Flood Reports")
        resolved_reports = fetch_flood_reports(status_filter="Resolved")

        if resolved_reports:
            for report in resolved_reports:
                st.markdown(f"""
                    <div style="background-color: #e0ffe0; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
                        <p><strong>Upazilla:</strong> {report[1]}</p>
                        <p><strong>Needs:</strong> {report[2]}</p>
                        <p><strong>Contact:</strong> {report[3]}</p>
                        <p><strong>Location:</strong> {report[4]}</p>
                        <p><strong>Source:</strong> {report[5]}</p>
                        <p><strong>Status:</strong> {report[6]}</p>
                        <p><strong>Flood Zone:</strong> {report[7] if len(report) > 7 else 'Not specified'}</p>
                    </div>
                """, unsafe_allow_html=True)
        else:
            st.write("No resolved reports available.")

    with col2:
        st.header("All Flood Reports")
        reports = fetch_flood_reports()

        if reports:
            for report in reports:
                with st.container():
                    st.markdown(f"""
                        <div style="background-color: #f0f0f0; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
                            <p><strong>Upazilla:</strong> {report[1]}</p>
                            <p><strong>Needs:</strong> {report[2]}</p>
                            <p><strong>Contact:</strong> {report[3]}</p>
                            <p><strong>Location:</strong> {report[4]}</p>
                            <p><strong>Source:</strong> {report[5]}</p>
                            <p><strong>Status:</strong> {report[6]}</p>
                            <p><strong>DateTime:</strong> {report[7] if len(report) > 7 else 'Not specified'}</p>
                        </div>
                    """, unsafe_allow_html=True)

                    col1, col2 = st.columns(2)
                    with col1:
                        if report[6] == 'Processing':
                            if st.button(f"Mark as Resolved (ID: {report[0]})", key=f"resolve_{report[0]}"):
                                if mark_as_resolved(report[0]):
                                    st.success(f"Report {report[0]} marked as resolved.")
                                    st.experimental_rerun()

                    with col2:
                        if st.button(f"Delete Report (ID: {report[0]})", key=f"delete_{report[0]}"):
                            if delete_flood_report(report[0]):
                                st.success(f"Report {report[0]} deleted.")
                                st.experimental_rerun()

                    st.write("---")
        else:
            st.write("No flood reports available.")

    st.header("Flood Risk Analysis")
    plot_flood_zones()

elif page == "Evacuation Centers":
    st.header("Evacuation Centers")
    centers = fetch_evacuation_centers()
    if centers:
        df = pd.DataFrame(centers, columns=['Center ID', 'Location', 'Capacity', 'Current Occupancy', 'Location ID'])
        st.dataframe(df)
    else:
        st.write("No evacuation centers available.")

elif page == "Response Actions":
    st.header("Response Actions Management")
    reports = fetch_flood_reports()
    if reports:
        for report in reports:
            with st.container():
                st.markdown(f"""
                    <div style="background-color: #f0f0f0; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
                        <p><strong>Upazilla:</strong> {report[1]}</p>
                        <p><strong>Needs:</strong> {report[2]}</p>
                        <p><strong>Contact:</strong> {report[3]}</p>
                        <p><strong>Location:</strong> {report[4]}</p>
                        <p><strong>Source:</strong> {report[5]}</p>
                        <p><strong>Status:</strong> {report[6]}</p>
                        <p><strong>Flood Zone:</strong> {report[7] if len(report) > 7 else 'Not specified'}</p>
                    </div>
                """, unsafe_allow_html=True)

                available_volunteers = fetch_available_volunteers()

                if available_volunteers:
                    volunteer_ids = [v[0] for v in available_volunteers]
                    selected_volunteer_id = st.selectbox("Select Volunteer", volunteer_ids, key=f"volunteer_{report[0]}")

                    if st.button(f"Respond to Report (ID: {report[0]})", key=f"respond_{report[0]}"):
                        action_taken = f"Assisted by Volunteer ID {selected_volunteer_id}"
                        if add_response_action(report[0], action_taken, selected_volunteer_id):
                            st.success(f"Response recorded for report ID {report[0]} with Volunteer ID {selected_volunteer_id}.")
                        else:
                            st.error("Failed to record the response.")
                else:
                    st.write("No available volunteers to respond.")
                st.write("---")
    else:
        st.write("No flood reports available.")

elif page == "Donations Management":
    st.header("Donations Management")
    st.markdown("Help us support flood victims by making a donation.")
    
    with st.form("donation_form"):
        donor_name = st.text_input("Donor Name")
        donation_amount = st.number_input("Donation Amount", min_value=1.00, format="%.2f")
        donation_type = st.text_input("Donation Type")
        submit_button = st.form_submit_button("Submit Donation")
        
        if submit_button:
            result = add_donation(donation_type, donation_amount, donor_name)
            st.success(result)
            st.experimental_rerun()

    total_donations = get_total_donations()
    st.markdown(f"### Total Donations Received: ${total_donations:,.2f}")

elif page == "Volunteer Management":
    st.header("Volunteer Management")
    
    with st.form("volunteer_form"):
        name = st.text_input("Volunteer Name")
        skills = st.text_input("Skills")
        contact_info = st.text_input("Contact Info")
        availability = st.selectbox("Availability", ["Available", "Unavailable"])

        submit_button = st.form_submit_button("Submit")
        
        if submit_button:
            try:
                query = text("""
                    INSERT INTO volunteers (availability, skills, contact_info) 
                    VALUES (:availability, :skills, :contact_info)
                """)
                with engine.begin() as conn:
                    conn.execute(query, {
                        "availability": availability,
                        "skills": skills,
                        "contact_info": contact_info
                    })
                st.success("Volunteer added successfully!")
            except SQLAlchemyError as e:
                st.error(f"An error occurred: {str(e)}")
