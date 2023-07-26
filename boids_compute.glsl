#[compute]
#version 450

layout(local_size_x = 10, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer containing boid positions
layout(set = 0, binding = 0, std430) restrict buffer BoidPositions {
    vec3 positions[];
};

// A binding to the buffer containing boid velocities
layout(set = 0, binding = 1, std430) restrict buffer BoidVelocities {
    vec3 velocities[];
};


void main(){
    uint index = gl_GlobalInvocationID.x;

    vec3 position = positions[index];
    vec3 velocity = velocities[index];
    position += vec3(0.01,0,0);

    positions[index] = position;
    velocities[index] = velocity;
}
/*void main() {

    float coherenceWeight = 1.0;
    float separationWeight = 1.0;
    float alignmentWeight = 1.0;
    float coherenceRadius = 1.0;
    float separationRadius = 2.0;
    float alignmentRadius = 3.0;
    uint index = gl_GlobalInvocationID.x;

    vec3 position = positions[index];
    vec3 velocity = velocities[index];

    vec3 coherence = vec3(0.0);
    vec3 separation = vec3(0.0);
    vec3 alignment = vec3(0.0);

    int countCoherence = 0;
    int countSeparation = 0;
    int countAlignment = 0;

    for (uint i = 0; i < positions.length(); i++) {
        if (i == index)
            continue;

        vec3 otherPosition = positions[i];
        float distance = distance(position, otherPosition);

        if (distance < coherenceRadius) {
            coherence += otherPosition;
            countCoherence++;
        }

        if (distance < separationRadius) {
            separation += (position - otherPosition) / distance;
            countSeparation++;
        }

        if (distance < alignmentRadius) {
            alignment += velocities[i];
            countAlignment++;
        }
    }

    if (countCoherence > 0) {
        coherence /= float(countCoherence);
        vec3 coherenceDirection = normalize(coherence - position);
        velocity += coherenceDirection * coherenceWeight;
    }

    if (countSeparation > 0) {
        separation /= float(countSeparation);
        vec3 separationDirection = normalize(separation);
        velocity += separationDirection * separationWeight;
    }

    if (countAlignment > 0) {
        alignment /= float(countAlignment);
        vec3 alignmentDirection = normalize(alignment);
        velocity += alignmentDirection * alignmentWeight;
    }




    // Limit the maximum speed of the boid if desired

    position += vec3(0.01,0,0);

    positions[index] = position;
    velocities[index] = velocity;

}
*/