using UnityEngine;
using System.Collections;

public class DiamondSpawner : MonoBehaviour {

    public GameObject[] prefabs;

    // Start is called before the first frame update
    void Start() {
        // infinite diamond spawning function
        StartCoroutine(SpawnDiamonds());
    }

    // Update is called once per frame
    void Update() {
    
    }

	IEnumerator SpawnDiamonds() {
		while (true) {

			// instantiate diamond
			Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);

            // pause 1-10 seconds until the next diamond spawns
			yield return new WaitForSeconds(Random.Range(1, 10));
		}
	}
}
